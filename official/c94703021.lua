--クラスター・コンジェスター
--Cluster Congester
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Congester Token"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon1)
	e1:SetTarget(s.tktg1)
	e1:SetOperation(s.tkop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Special Summon "Congester Tokens" up to the number of Link monsters the opponent controls
	local e3=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e3:SetCondition(s.tkcon2)
	e3:SetCost(s.tkcost2)
	e3:SetTarget(s.tktg2)
	e3:SetOperation(s.tkop2)
	c:RegisterEffect(e3)
end
s.listed_names={94703022}
function s.tkcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsLinkMonster,tp,LOCATION_MZONE,0,nil)==0
end
function s.tktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		local tk=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	local g=Duel.GetMatchingGroup(Card.IsLinkMonster,tp,LOCATION_MZONE,0,nil)
	return at and g:IsContains(at)
end
function s.tkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttackTarget()
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and at and at:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,at)>0 end
	local g=Group.FromCards(e:GetHandler(),at)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLinkMonster,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then return end
	local ct=math.min(Duel.GetMatchingGroupCount(Card.IsLinkMonster,tp,0,LOCATION_MZONE,nil),Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	if ct>1 then
		ct=Duel.AnnounceNumberRange(tp,1,ct)
	end
	for i=1,ct do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end