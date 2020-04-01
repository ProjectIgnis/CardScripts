--トイ・マジシャン
local s,id=GetID()
function s.initial_effect(c)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and rp~=tp then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct>#g then ct=#g end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
