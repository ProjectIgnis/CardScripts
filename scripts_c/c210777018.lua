--Apoqliporth Eradicator
--designed by Natalia, scripted by Naim
function c210777018.initial_effect(c)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--tribute limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c210777018.tlimit)
	c:RegisterEffect(e2)
	--summon with 3 tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777018,0))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e3:SetCondition(c210777018.ttcon)
	e3:SetOperation(c210777018.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e4)
	--immune
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetCondition(c210777018.immcon)
	e5:SetValue(c210777018.efilter)
	c:RegisterEffect(e5)
	--search
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(210777018,1))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c210777018.thcd)
	e6:SetTarget(c210777018.thtg)
	e6:SetOperation(c210777018.thop)
	c:RegisterEffect(e6)
end
function c210777018.tlimit(e,c)
	return not c:IsSetCard(0xaa)
end
function c210777018.val(c,sc,ma)
	local eff3={c:GetCardEffect(EFFECT_TRIPLE_TRIBUTE)}
	if ma>=3 then
		for _,te in ipairs(eff3) do
			if type(te:GetValue())~='function' or te:GetValue()(te,sc) then return 0x30001 end
		end
	end
	local eff2={c:GetCardEffect(EFFECT_DOUBLE_TRIBUTE)}
	for _,te in ipairs(eff2) do
		if type(te:GetValue())~='function' or te:GetValue()(te,sc) then return 0x20001 end
	end
	return 1
end
function c210777018.rescon(sg,e,tp,mg)
	local ct=sg:GetCount()
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:CheckWithSumEqual(c210777018.val,3,ct,ct,e:GetHandler(),3)
end
function c210777018.ttcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetTributeGroup(c)
	return minc<=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and aux.SelectUnselectGroup(g,e,tp,1,3,c210777018.rescon,0)
end
function c210777018.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetTributeGroup(c)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,c210777018.rescon,1,tp,HINTMSG_RELEASE,c210777018.rescon)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
function c210777018.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
function c210777018.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true
	else return aux.qlifilter(e,te) end
end
function c210777018.thfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xaa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210777018.thcd(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp 
end
function c210777018.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210777018.thfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function c210777018.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(210777018,2))
	local g=Duel.SelectMatchingCard(tp,c210777018.thfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end	
end
