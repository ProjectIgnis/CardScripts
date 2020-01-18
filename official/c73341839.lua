--ショートヴァレル・ドラゴン
--Miniborrel Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x102),2,2)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x10f,0x102}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f) and c:IsLinkMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.rfilter(c)
	return c:IsLinkBelow(3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) 
		and Duel.CheckReleaseGroupCost(tp,s.rfilter,1,false,aux.ReleaseCheckMMZ,nil) end
	local rg=Duel.SelectReleaseGroupCost(tp,s.rfilter,1,1,false,aux.ReleaseCheckMMZ,nil)
	local r=rg:GetFirst()
	local lk=r:GetLink()
	e:SetLabel(lk)
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(s.lnklimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(e:GetLabel())
		c:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function s.lnklimit(e,c)
	if not c then return false end
	return c:IsLink(e:GetLabel())
end

