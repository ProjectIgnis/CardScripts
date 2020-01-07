--Scab Scarknight(Anime)
--scripted by:urielkama
--added Scab Counter placing and remove Self Destruction position related
local s,id=GetID()
function s.initial_effect(c)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--must attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e3)	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_MUST_BE_ATTACKED)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
	--counter
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLED)
	e5:SetCondition(s.ctcon)
	e5:SetTarget(s.cttg)
	e5:SetOperation(s.ctop)
	c:RegisterEffect(e5)
	--control
	local e6=Effect.CreateEffect(c)		
	e6:SetCategory(CATEGORY_CONTROL)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_REPEAT)
	e6:SetCountLimit(1)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetTarget(s.target)
	e6:SetOperation(s.activate)
	c:RegisterEffect(e6)		
	--only 1 can exists
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_SUMMON)
	e7:SetCondition(s.excon)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EFFECT_SPSUMMON_CONDITION)
	e9:SetValue(s.splimit)
	c:RegisterEffect(e9)
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_SELF_DESTROY)
	ea:SetCondition(s.descon)
	c:RegisterEffect(ea)
	--negate
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_QUICK_F)
	e10:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e10:SetCode(EVENT_CHAINING)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCondition(s.con)
	e10:SetTarget(s.tg)
	e10:SetOperation(s.op)
	c:RegisterEffect(e10)
end
function s.indescon(e)
	return e:GetHandler():IsAttackPos()
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc:IsRelateToBattle() and tc
		and not tc:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,tc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x109a,1)
	end
end
function s.cfilter(c,tp)
	return c:GetControler()~=tp and c:IsFaceup() and c:IsControlerCanBeChanged() and c:GetCounter(0x109a)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,ft,ft,nil,tp)
	local tc=g:GetFirst()
	while tc do
		Duel.GetControl(tc,tp)
		tc=g:GetNext()
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return re:IsHasCategory(CATEGORY_RECOVER)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
function s.exfilter(c,fid)
	return c:IsFaceup() and c:GetCode()==511004127 and (fid==nil or c:GetFieldID()<fid)
end
function s.excon(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.exfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function s.splimit(e,se,sp,st,spos,tgp)
	return not Duel.IsExistingMatchingCard(s.exfilter,tgp,LOCATION_ONFIELD,0,1,nil)
end
function s.descon(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.exfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil,c:GetFieldID())
end
