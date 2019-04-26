--Youkai Sorceress, Enpo
function c210300303.initial_effect(c)
	aux.EnableDualAttribute(c)
	--decrease tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65959844,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetCondition(c210300303.ntcon)
	e1:SetTarget(c210300303.nttg)
	c:RegisterEffect(e1)
	--on release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c210300303.checkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c210300303.rcon)
	e3:SetTarget(c210300303.rtg)
	e3:SetOperation(c210300303.rop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function c210300303.ntcon(e,c,minc)
	if c==nil then return true end
	return aux.IsDualState(e) and minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c210300303.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_DUAL) and c:IsRace(RACE_ZOMBIE)
end
function c210300303.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsDualState() and c:IsReason(REASON_RELEASE) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function c210300303.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function c210300303.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
end
function c210300303.rop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if tc:IsRelateToEffect(e) then Duel.GetControl(tc,tp,0,0) end
end
