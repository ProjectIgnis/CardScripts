--氷結界の晶壁
--Clear Wall of the Ice Barrier
--Scripted by Hel

local s,id=GetID()
function s.initial_effect(c)
	--Activate and Special Summon from GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Unaffected by activated effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(s.unacon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.unaval)
	c:RegisterEffect(e2)
end
s.listed_series={0x2f}

function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x2f) and c:IsLevelBelow(4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return true end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e:SetOperation(s.activate)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
			e:SetCategory(0)
			e:SetProperty(0)
			e:SetOperation(nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.unafilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
function s.unacon(e)
	return Duel.IsExistingMatchingCard(s.unafilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
function s.unaval(e,te)
	local tc=te:GetOwner()
	return tc:IsSummonType(SUMMON_TYPE_SPECIAL) and tc:GetSummonLocation()==LOCATION_EXTRA and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end