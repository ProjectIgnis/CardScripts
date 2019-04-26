--Ultimate Madoka
function c210533308.initial_effect(c)
	c:EnableReviveLimit()
	--special summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c210533308.scon)
	c:RegisterEffect(e1)
	--immuny to other monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c210533308.iev)
	c:RegisterEffect(e2)
	--place as many counter
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c210533308.pmct)
	e3:SetOperation(c210533308.pmco)
	c:RegisterEffect(e3)
end
function c210533308.scon(e,se,sp,st)
	return se and se:GetHandler():IsCode(210533301)
end
function c210533308.iev(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c210533308.pmcf(c)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsCanAddCounter(0x1,1)
end
function c210533308.pmct(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c210533308.pmcf,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil) end
	Duel.SelectTarget(tp,c210533308.pmcf,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,99,nil)
end
function c210533308.gf(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function c210533308.pmco(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(c210533308.gf,nil,e)
	for tc in aux.Next(g) do
		local counter_max=0
		while tc:IsCanAddCounter(0x1,counter_max+1) do
			counter_max=counter_max+1
		end
		tc:AddCounter(0x1,counter_max,true)
	end
end