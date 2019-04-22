--Solar Fruit - Revivafruit
function c210001516.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c210001516.condition)
	e1:SetTarget(c210001516.target)
	e1:SetOperation(c210001516.operation)
	c:RegisterEffect(e1)
	--add to hand 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c210001516.cost)
	e2:SetTarget(c210001516.thtarget)
	e2:SetOperation(c210001516.thoperation)
	c:RegisterEffect(e2)
	if not c210001516.gchk then
		c210001516.gchk=true
		for i=0,1 do
			c210001516[i]=Group.CreateGroup()
			c210001516[i]:KeepAlive()
		end
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_DESTROY)
		ge:SetOperation(c210001516.gop)
		Duel.RegisterEffect(ge,0)
	end
end
function c210001516.gop(e,tp,eg,ep,ev,re,r,rp)
	if not eg then return end
	for c in aux.Next(eg) do
		if c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1f69) then
			c210001516[c:GetControler()]:Merge(c:GetEquipGroup())
		end
	end
end
function c210001516.f(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1f69) and c:GetPreviousControler()==tp
end
function c210001516.condition(e,tp,eg,ep,ev,re,r,rp)
	if not eg then return false end
	if #eg==1 then
		local c=eg:GetFirst()
		if c210001516.f(c,tp) then
			e:SetLabelObject(c)
			return true
		end
		return false
	else
		return false
	end
end
function c210001516.filter(c,e,tp,code)
	return c:IsSetCard(0xf69) and c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210001516.target(e,tp,eg,ev,re,r,rp,chk)
	local pc=e:GetLabelObject()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c210001516.filter,tp,0x13,0,1,nil,e,tp,pc:GetCode())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
function c210001516.efilter(c,pg,pc)
	return c:IsSetCard(0xf70) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and pg:IsContains(c)
end
function c210001516.operation(e,tp,eg,ev,epxc,re,r,rp)
	local c=e:GetHandler()
	local pc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c210001516.filter),tp,0x13,0,1,1,nil,e,tp,pc:GetCode())
	if g and #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		local ac=g:GetFirst()
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local peg=c210001516[tp]
		local eg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c210001516.efilter),tp,LOCATION_GRAVE,0,1,ft,nil,peg,pc)
		if #eg>0 then
			for tc in aux.Next(eg) do
				Duel.Equip(tp,tc,ac)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetLabelObject(ac)
				e1:SetValue(c210001516.eqlimit)
				tc:RegisterEffect(e1)
			end
		end
		peg:Clear()
	end
end
function c210001516.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c210001516.sff(c,m)
	return c:IsSetCard(0xf71) and ((m==1 and c:IsAbleToHand()) or (m==0 and c:IsAbleToRemoveAsCost()))
end
function c210001516.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741)
		and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c210001516.sff,tp,LOCATION_GRAVE,0,1,c,0) end
	local g=Duel.SelectMatchingCard(tp,c210001516.sff,tp,LOCATION_GRAVE,0,1,1,c,0)
	g=g+c
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210001516.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001516.sff,tp,LOCATION_DECK,0,1,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210001516.thoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001516.sff,tp,LOCATION_DECK,0,1,1,nil,1)
	if g and #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end