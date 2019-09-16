--死霊王 ドーハスーラ
--Doomking Balerdorch
local s,id=GetID()
function s.initial_effect(c)
	--negate and/or banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.disrmcon)
	e1:SetCost(s.disrmcost)
	e1:SetTarget(s.disrmtg)
	e1:SetOperation(s.disrmop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.disrmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.disrmcon(e,tp,eg,ep,ev,re,r,rp)
	local race,code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return race&RACE_ZOMBIE>0 and code1~=id and code2~=id
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.disrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsChainDisablable(ev) and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
		and Duel.GetFlagEffect(tp,id+1)==0
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.disrmop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsChainDisablable(ev) and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
		and Duel.GetFlagEffect(tp,id+1)==0
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else return end
	if op==0 then
		Duel.NegateEffect(ev)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end