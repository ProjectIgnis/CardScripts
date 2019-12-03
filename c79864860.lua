--捕食植物トリフィオヴェルトゥム
--Predaplant Triphyoverutum
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--disable special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.counter_list={COUNTER_PREDATOR}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsOnField()
end
function s.vfilter(c)
	return c:IsFaceup() and c:GetCounter(COUNTER_PREDATOR)>0
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.vfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c)
	return g:GetSum(Card.GetBaseAttack)
end
function s.disfilter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0 and eg:IsExists(s.disfilter,1,nil) and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
	Duel.NegateSummon(g)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.cfilter(c)
	return c:IsFaceup() and c:GetCounter(COUNTER_PREDATOR)>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
