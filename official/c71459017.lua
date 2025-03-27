--禰須三破鳴比
--Hinezumi Hanabi
--scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x203)
	--Cannot be used as material for a Fusion/Synchro/Xyz/Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e1)
	--Place counters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Give control to your opponent
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.ctlcon)
	e4:SetTarget(s.ctltg)
	e4:SetOperation(s.ctlop)
	c:RegisterEffect(e4)
	--Remove counters
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DICE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_CONTROL_CHANGED)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.roll_dice=true
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x203)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x203,6)
	end
end
function s.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged() end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.GetControl(c,1-tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x203)>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x203,1,REASON_EFFECT) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsCanRemoveCounter(tp,0x203,1,REASON_EFFECT) then return end
	local ct=math.min(Duel.TossDice(tp,1),c:GetCounter(0x203))
	c:RemoveCounter(tp,0x203,ct,REASON_EFFECT)
	if c:GetCounter(0x203)==0 and Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.Damage(tp,2000,REASON_EFFECT)
	end
end