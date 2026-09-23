--“罪宝狩りの悪魔”ディアベルスター
--Diabellstar, the Seeker of Sinful Spoils
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If "Sinful Spoils of Subversion - Snake-Eye" or "Snake-Eyes Poplar" is in either GY, you can Special Summon this card (from your hand). You can only Special Summon "Diabellstar, the Seeker of Sinful Spoils" once per turn this way
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--You can banish 1 "Sinful Spoils of Doom - Rciela" from your GY; destroy all Spells/Traps your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(c.descost(16240772))
	e2:SetTarget(s.destg(Card.IsSpellTrap))
	e2:SetOperation(s.desop(Card.IsSpellTrap))
	c:RegisterEffect(e2)
	--During your opponent's turn (Quick Effect): You can banish 1 "Sinful Spoils of Betrayal - Silvera" from your GY; destroy all monsters your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e3:SetCost(c.descost(38511382))
	e3:SetTarget(s.destg(Card.IsMonster))
	e3:SetOperation(s.desop(Card.IsMonster))
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
end
s.listed_names={24081957,90241276,16240772,38511382}
--"Sinful Spoils of Subversion - Snake-Eye"
--"Snake-Eyes Poplar"
--"Sinful Spoils of Doom - Rciela"
--"Sinful Spoils of Betrayal - Silvera"
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCode,0,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,24081957,90241276)
end
function s.descostfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
function s.descost(code)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_GRAVE,0,1,nil,code) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_GRAVE,0,1,1,nil,code)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.destg(filter)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local g=Duel.GetMatchingGroup(filter,tp,0,LOCATION_ONFIELD,nil)
		if chk==0 then return #g>0 end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
end
function s.desop(filter)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(filter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end