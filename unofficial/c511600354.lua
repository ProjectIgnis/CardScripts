--サイバネット・クロージャ
--Cynet Closure
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)--+EFFECT_COUNT_CODE_OATH
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.tgcon)
		e1:SetOperation(s.tgop)
		tc:RegisterEffect(e1)
	end
end
function s.tgfilter(c,tp)
	if not c:IsStatus(STATUS_OPPO_BATTLE) or c:GetBattleTarget():GetPreviousTypeOnField()&TYPE_LINK~=TYPE_LINK then return false end
	if c:IsRelateToBattle() then
		return c:IsControler(tp) and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
	else
		return c:GetPreviousControler()==tp and c:GetPreviousRaceOnField()&RACE_CYBERSE==RACE_CYBERSE
			and c:GetPreviousTypeOnField()&TYPE_LINK==TYPE_LINK
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tgfilter,1,nil,tp)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_RETURN)
end
