--Yokai Leader, Showa
function c210300314.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMixRep(c,true,true,c210300314.ffilter,3,99)
	aux.AddContactFusion(c,c210300314.contactfil,c210300314.contactop,c210300314.splimit)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	e1:SetCode(EFFECT_DUAL_STATUS)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72989439,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c210300314.rmtg)
	e2:SetOperation(c210300314.rmop)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c210300314.reptg)
	e3:SetValue(c210300314.repval)
	e3:SetOperation(c210300314.repop)
	c:RegisterEffect(e3)
end
c210300314.material_setcode={0x93,0x1093}
function c210300314.ffilter(c,fc,sumtype,tp,sub,mg,sg,contact)
	if contact then sumtype=0 end
	return c:GetCode()>210300300 and c:GetCode()<210300400 and (not contact or c:IsType(TYPE_MONSTER,fc,sumtype,tp))
		and (not sg or not sg:IsExists(c210300314.fusfilter,1,c,c:GetCode()))
end
function c210300314.fusfilter(c,code)
	return c:IsCode(code) or c:IsHasEffect(511002961)
end
function c210300314.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c210300314.contactfil(tp)
	return Duel.GetMatchingGroup(c210300314.cfilter,tp,LOCATION_ONFIELD,0,nil,tp)
end
function c210300314.cfilter(c,tp)
	return c:IsAbleToGraveAsCost()
end
function c210300314.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
	--indes count
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(g:GetCount())
	e1:SetValue(c210300314.valcon)
	c:RegisterEffect(e1)
end
function c210300314.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
function c210300314.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetLocation()==LOCATION_MZONE and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c210300314.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function c210300314.repfilter(c,tp)
	return c:IsFaceup() and c:GetCode()>210300300 and c:GetCode()<210300400 and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsAbleToDeck()
end
function c210300314.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetCount()==1 and eg:IsExists(c210300314.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c210300314.repval(e,c)
	return c210300314.repfilter(c,e:GetHandlerPlayer())
end
function c210300314.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SendtoDeck(eg,nil,2,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
