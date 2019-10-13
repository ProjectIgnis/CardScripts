--ハイドライブ・アクセラレーター
--Hydradrive Accelerator
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x577))
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(function(e,c) return e:GetHandler():GetEquipTarget():IsAttribute(ATTRIBUTE_EARTH) end)
	c:RegisterEffect(e1)
	--immune
	local e2=e1:Clone()
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={0x577}
function s.efilter(e,re)
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	return c:GetControler()~=re:GetOwnerPlayer()
		and (eqc:IsAttribute(ATTRIBUTE_WATER) and re:IsActiveType(TYPE_TRAP)
		or eqc:IsAttribute(ATTRIBUTE_FIRE) and re:IsActiveType(TYPE_SPELL))
end
function s.tfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local eqc=e:GetHandler():GetEquipTarget()
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) 
		and g and g:IsExists(s.tfilter,1,eqc,tp) and Duel.IsChainDisablable(ev)
		and eqc:IsAttribute(ATTRIBUTE_WIND)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end