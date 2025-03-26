--サイバー・レイダー
--Cyber Raider
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.desfilter(c)
	return c:IsType(TYPE_EQUIP) and c:GetEquipTarget()
end
function s.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:GetEquipTarget()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local label=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsType(TYPE_EQUIP) and chkc:GetEquipTarget()
		and (label==1 or (label==2 and chkc:CheckEquipTarget(c)))
	end
	if chk==0 then return true end
	local b1=Duel.IsExistingTarget(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
	local b2=Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,c)
	local sel=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(sel or 0)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
		if #g>0 then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
		end
	elseif sel==2 then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,c)
		if #g>0 then
			Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
		end
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then return end
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	local c=e:GetHandler()
	if sel==1 and s.desfilter(tc) then
		--Destroy 1 Equip Card on the field
		Duel.Destroy(tc,REASON_EFFECT)
	elseif sel==2 and c:IsRelateToEffect(e) and s.eqfilter(tc,c) then
		--Equip 1 Equip Card on the field to this card
		Duel.Equip(tp,tc,c)
	end
end