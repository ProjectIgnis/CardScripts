--サイバー・レイダー
--Cyber Raider
local s,id=GetID()
function s.initial_effect(c)
	--Destroy or equip 1 Equip Card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.desfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup() and c:GetEquipTarget()
end
function s.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:IsFaceup() and c:GetEquipTarget()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then return chkc:IsLocation(LOCATION_SZONE) and s.desfilter(chkc)
		else return chkc:IsLocation(LOCATION_SZONE) and s.eqfilter(chkc,e:GetHandler()) end
	end
	if chk==0 then return true end
	local sel=Duel.SelectEffect(tp,
		{Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil),aux.Stringid(id,1)},
		{Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler(),aux.Stringid(id,2))})
	e:SetLabel(sel or 0)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
		if #g>0 then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		end
	elseif sel==2 then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e:GetHandler())
		if #g>0 then
			Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
		end
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then return end
	local tc=Duel.GetFirstTarget()
	if sel==1 then
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		local c=e:GetHandler()
		if tc:IsRelateToEffect(e) then
			Duel.Equip(tp,tc,c)
		end
	end
end
