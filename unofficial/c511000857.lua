--Harmony Crystal
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter1(c,e,tid)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.cfilter2,c:GetControler(),LOCATION_GRAVE,0,1,c,c,e)
		and c:IsReason(REASON_DESTROY) and c:GetTurnID()==tid
end
function s.cfilter2(c,ban1,e)
	local tp=c:GetControler()
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ban1,c)
end
function s.filter(c,e,tp,ban1,ban2)
	return c:IsType(TYPE_SYNCHRO) and c~=ban1 and c~=ban2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tid=Duel.GetTurnCount()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741) 
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tid) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg1=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tid)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg2=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,cg1:GetFirst(),cg1:GetFirst(),e)
	cg1:Merge(cg2)
	Duel.Remove(cg1,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,nil,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Damage(1-tp,tc:GetAttack()/2,REASON_EFFECT)
	end
end
