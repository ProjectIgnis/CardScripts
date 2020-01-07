--Reckless Parasite
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Parasitize
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetValue(RACE_INSECT)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetOperation(s.eqop)
	e5:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
end
s.listed_names={27911549,511004345}
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter(c,e,tp)
	return c:IsCode(27911549) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 and Duel.IsPlayerCanSpecialSummon(tp) end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
	e:GetHandler():RegisterEffect(e2)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,0)
		tc=g:GetNext()
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,0,LOCATION_DECK,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c) return c:GetFlagEffect(id)>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	g:KeepAlive()
	s.eqop(e,tp,g,ep,ev,re,r,rp)
	g:DeleteGroup()
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,27911549)
		and Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,id)
end
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.tg(e,c)
	local g=c:GetEquipGroup()
	return g and g:IsExists(Card.IsCode,1,nil,511004345)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		local token=Duel.CreateToken(tp,511004345)
		Duel.Equip(tp,token,tc)
		local e1=Effect.CreateEffect(token)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function s.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
