--エコール・ド・ゾーン
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--cannot direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsType,TYPE_TOKEN)))
	c:RegisterEffect(e4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return #eg==1 and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local p=tc:GetControler()
		local pos=tc:GetPosition()
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			local token=Duel.CreateToken(tp,id+1)
			if Duel.SpecialSummonStep(token,0,tp,p,false,false,pos) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e1,true)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_BASE_DEFENSE)
				e2:SetValue(def)
				token:RegisterEffect(e2,true)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
