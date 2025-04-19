--Amazoness Audience Room
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--trigger
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(s.descon)
	c:RegisterEffect(e4)
end
s.listed_series={0x4}
function s.tgfilter(c,e,tp)
	return c:IsControler(1-tp) and (not e or c:IsRelateToEffect(e))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.tgfilter,1,nil,nil,tp) end
	local g=eg:Filter(s.tgfilter,nil,nil,tp)
	Duel.SetTargetCard(eg)
	local sum=g:GetSum(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,sum)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(s.tgfilter,nil,e,tp)
	local sum=g:GetSum(Card.GetAttack)
	Duel.Recover(tp,sum,REASON_EFFECT)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_AMAZONESS)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end