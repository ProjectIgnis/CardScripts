--Summon Capture
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
end
function s.filter(c)
	return c:IsSummonable(true,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(p,g)
		local tg2=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		local tg=tg2:Filter(s.filter,nil)
		if #tg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg=tg:Select(p,1,1,nil)
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
		Duel.ShuffleHand(1-p)
	end
end
