--Noah's Arc
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_names={86327225,60365591} --"Shinato, King of A Higher Plane", "Shinato's  Ark"
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Once per Duel, you can add 1 "Shinato, King of a Higher Plane" or "Shinato's Ark" from your Deck to your hand, then place 1 card from your hand on the bottom of the Deck. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetCondition(s.shinatotohandcon)
	e1:SetOperation(s.shinatotohandop)
	Duel.RegisterEffect(e1,tp)
	--Once per turn, if you control a Level 5 or higher Spirit monster or "Shinato, King of a Higher Plane", you can add 1 Spirit monster from your GY to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCountLimit(1)
	e2:SetRange(0x5f)
	e2:SetCondition(s.spirittohandcon)
	e2:SetOperation(s.spirittohandop)
	Duel.RegisterEffect(e2,tp)
	--During your turn, you can Normal Summon 1 Spirit monster with the same original name as a monster that was Normal Summoned during your previous turn, in addition to your Normal Summon this turn.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(0x5f)
	e3:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return s[0][c:GetOriginalCode()]~=nil and c:IsType(TYPE_SPIRIT) end)
	Duel.RegisterEffect(e3,tp)
	--Register monsters Normal Summoned on your turn
	aux.GlobalCheck(s,function()
		s[0]={} --previous
    	s[1]={} --current
        local ge1=Effect.CreateEffect(c)
    	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
        		if Duel.GetTurnPlayer()==ge1:GetHandlerPlayer() then 
				s[0]=s[1] --set "previous" to "current"
				s[1]={} --reset current
			end
		end)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsTurnPlayer(e:GetHandlerPlayer()) then
		for tc in eg:Iter() do
			s[1][tc:GetOriginalCode()]=true
		end
	end
end
--Functions to add "Shinato, King of a Higher Plane" or "Shinato's Ark" from Deck to hand
function s.shinatotohandfilter(c)
	return (c:IsCode(86327225) or c:IsCode(60365591)) and c:IsAbleToHand()
end
function s.shinatotohandcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.shinatotohandfilter,tp,LOCATION_DECK,0,1,nil) and not Duel.HasFlagEffect(tp,id)
end
function s.shinatotohandop(e,tp,eg,ep,ev,re,r,rp)
	--Skill Activation
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--You can only use this Skill once per Duel
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Add 1 "Shinato, King of a Higher Plane" or "Shinato's Ark" from your Deck to your hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.shinatotohandfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,tp,REASON_EFFECT) and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
--Functions to add Spirit monster from GY to hand
function s.cfilter(c)
	return c:IsFaceup() and ((c:IsType(TYPE_SPIRIT) and c:IsLevelAbove(5)) or c:IsCode(86327225)) 
end
function s.spirittohandfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end
function s.spirittohandcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spirittohandfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.spirittohandop(e,tp,eg,ep,ev,re,r,rp)
	--Skill Activation
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Add 1 Spirit monster from your GY to your hand if you control a Level 5 or higher Spirit monster or "Shinato, King of a Higher Plane"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spirittohandfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
