--Subverted Enalpaes
function c210001109.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xfed),2)
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c210001109.cacondition)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	--to be reworked later when im sure.
	if not aux.imval2 then
		e1:SetValue(aux.imval1)
	else
		e1:SetValue(aux.imval2)
	end
	c:RegisterEffect(e1)
	--return to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c210001109.rettarget)
	e2:SetOperation(c210001109.retoperation)
	c:RegisterEffect(e2)
end
function c210001109.caconditionfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfed)
end
function c210001109.cacondition(e)
	return Duel.IsExistingMatchingCard(c210001109.caconditionfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function c210001109.retfilter(c,lg)
	return c:IsAbleToHand() and lg:IsContains(c)
end
function c210001109.rettarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chk==0 then return Duel.IsExistingMatchingCard(c210001109.retfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	thg=lg:Filter(c210001109.retfilter,nil,lg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,thg,1,0,0)
end
function c210001109.spfilter(c,e,tp,zone,sp)
	--0xfed==4077=="subverted"
	return c:IsSetCard(0xfed) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,sp,zone)
end
function c210001109.retoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local thg=Duel.SelectMatchingCard(tp,c210001109.retfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg)
	if thg:GetCount()>0 then
		local thc=thg:GetFirst()
		local seq=thc:GetSequence()
		local zone=0x1<<seq
		local sp=thc:GetControler()
		if Duel.SendtoHand(thc,nil,REASON_EFFECT)~=0 then
			local sg=Duel.SelectMatchingCard(tp,c210001109.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone,sp)
			local sc=sg:GetFirst()
			if sc then
				Duel.SpecialSummon(sc,0,tp,sp,false,false,POS_FACEUP,zone)
			end
		end
	end
end
