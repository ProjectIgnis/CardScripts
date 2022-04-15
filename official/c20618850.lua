-- まどろみの神碑
-- Mysterune of the Golden Droplets
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateMysteruneQPEffect(c,id,CATEGORY_DRAW,s.drtg,s.drop,4,EFFECT_FLAG_PLAYER_TARGET)
	c:RegisterEffect(e1)
end
s.listed_series={0x180}
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>4 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	return Duel.Draw(p,1,REASON_EFFECT)>0
end