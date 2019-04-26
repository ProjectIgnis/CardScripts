--Elemelon-tal Farmistress Doriado
--AlphaKretin
function c210310006.initial_effect(c)
	--Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND+ATTRIBUTE_LIGHT)
	c:RegisterEffect(e1)
	--On summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c210310006.target)
	e2:SetOperation(c210310006.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function c210310006.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf31)
end
function c210310006.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c210310006.ccount(g)
	local att=0
	for tc in aux.Next(g) do
		if tc then att=bit.bor(att,tc:GetAttribute()) end
	end
	local ct=0
	while att~=0 do
		if bit.band(att,0x1)~=0 then ct=ct+1 end
		att=bit.rshift(att,1)
	end
	return ct
end
function c210310006.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND) and c:IsAbleToHand()
end
function c210310006.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=Duel.GetMatchingGroup(c210310006.cfilter,tp,LOCATION_MZONE,0,c)
	cg:KeepAlive()
	local ct=c210310006.ccount(cg)
	local dt=Duel.GetMatchingGroupCount(c210310006.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local b1=dt>=ct
	local b2=Duel.IsExistingMatchingCard(c210310006.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(4031,7)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(4031,8)
		opval[off-1]=2
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY)
		local g=Duel.GetMatchingGroup(c210310006.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,LOCATION_SZONE)
	elseif sel==2 then
		e:SetCategory(CATEGORY_TOHAND)
		local g=Duel.GetMatchingGroup(c210310006.thfilter,tp,LOCATION_DECK,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function c210310006.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	local c=e:GetHandler()
	if sel==1 then
		local cg=Duel.GetMatchingGroup(c210310006.cfilter,tp,LOCATION_MZONE,0,c)
		cg:KeepAlive()
		local ct=c210310006.ccount(cg)
		if ct>0 then
			local g=Duel.SelectMatchingCard(tp,c210310006.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif sel==2 then
		local g=Duel.SelectMatchingCard(tp,c210310006.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
