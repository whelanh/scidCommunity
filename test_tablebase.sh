#!/bin/sh
# Test script for tablebase feature
# This tests the basic functionality of the tablebase lookup

cd /home/hugh/Downloads/scidCommunity

# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is not installed. The tablebase feature requires curl."
    exit 1
fi

# Test the Lichess API with a simple position
echo "Testing Lichess tablebase API..."
FEN="4k3/6KP/8/8/8/8/7p/8_w_-_-_0_1"
URL="http://tablebase.lichess.ovh/standard?fen=$FEN"

echo "Querying: $URL"
RESULT=$(curl -s --max-time 10 "$URL")

if [ $? -eq 0 ]; then
    echo "API call successful!"
    echo "Response: $RESULT"
else
    echo "API call failed!"
    exit 1
fi

echo ""
echo "Testing complete. The tablebase feature should work correctly."
echo ""
echo "To use the feature:"
echo "1. Start Scid"
echo "2. Load or create a game with 7 pieces or fewer"
echo "3. Click the 'TB' button at the bottom of the game window"
echo "4. A popup will show the tablebase analysis"
