--Double Parasitic Rebirth
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.filter(c,ft1,ft2,tp)
	local p=c:GetControler()
	if c:IsFacedown() then return false end
	local g1=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,6205579)
	local g2=Duel.GetMatchingGroupCount(Card.IsCode,tp,0,LOCATION_GRAVE,nil,6205579)
	local ft=0
	if Duel.GetLocationCount(p,LOCATION_SZONE)<=1 then return false end
	if g1>1 and ft1>1 then return true end
	if g2>1 and ft2>1 then return true end
	if g1>0 and g2>0 and ft1>0 and ft2>0 then return true end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft1=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft1=ft1-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,ft1,ft2,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ft1,ft2,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,ft1,ft2,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,2,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and s.filter(tc,ft1,ft2,tp) then
		local p=tc:GetControler()
		if Duel.GetLocationCount(p,LOCATION_SZONE)<=1 then return end
		local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,6205579)
		local g2=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_GRAVE,nil,6205579)
		local chk1=#g1>1 and ft1>1
		local chk2=#g2>1 and ft2>1
		local chk3=#g2>0 and ft2>0 and #g1>0 and ft1>0
		local eqg
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(12152769,2))
		if chk1 and chk2 and chk3 then
			g1:Merge(g2)
			eqg=g1:Select(tp,2,2,nil)
		elseif chk1 and not chk3 then
			eqg=g1:Select(tp,2,2,nil)
		elseif chk2 and not chk3 then
			eqg=g2:Select(tp,2,2,nil)
		else
			g1:Merge(g2)
			eqg=g1:Select(tp,1,1,nil)
			local tc=eqg:GetFirst()
			if tc:IsControler(tp) then ft1=ft1-1 else ft2=ft2-1 end
			if ft1<=0 then g1:Remove(Card.IsControler,nil,tp) end
			if ft2<=0 then g1:Remove(Card.IsControler,nil,1-tp) end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(12152769,2))
			local sel=g1:Select(tp,1,1,tc)
			eqg:Merge(sel)
		end
		Duel.HintSelection(eqg)
		local eqc=eqg:GetFirst()
		while eqc do
			if Duel.Equip(eqc:GetControler(),eqc,tc) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				e1:SetValue(s.eqlimit)
				e1:SetLabelObject(tc)
				eqc:RegisterEffect(e1)
				eqc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0)
			end
			eqc=eqg:GetNext()
		end
		Duel.EquipComplete()
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ADJUST)
		e2:SetRange(LOCATION_MZONE)
		e2:SetOperation(s.ctop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end	
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.ctfilter(c,tp)
	return c:GetFlagEffect(id)>0 and c:GetControler()~=tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetControler()
	local g=c:GetEquipGroup():Filter(s.ctfilter,nil,p)
	local tc=g:GetFirst()
	while tc do
		Duel.MoveToField(tc,p,p,LOCATION_SZONE,POS_FACEUP,true)
		Duel.Equip(p,tc,c)
		tc=g:GetNext()
	end
	Duel.EquipComplete()
end
