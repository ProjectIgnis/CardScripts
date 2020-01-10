--デストーイ・マイスター (Anime)
--Frightfur Meister (Anime)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.atkcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4013,9))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--special summon ex
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4013,10))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.excost)
	e3:SetTarget(s.extg)
	e3:SetOperation(s.exop)
	c:RegisterEffect(e3)
end
s.listed_series={0xad,0xa9,0xc3}
function s.spcheck(sg,tp,exg,e)
	return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.exfilter(c,e,tp,sg)
	return c:IsSetCard(0xad) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsType(TYPE_FUSION)
		and c:IsLevel(sg:GetSum(Card.GetLevel)) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
function s.cgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xad)
end
function s.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.cgfilter,0,false,s.spcheck,nil,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mg=Duel.SelectReleaseGroupCost(tp,s.cgfilter,1,99,false,s.spcheck,nil,e)
	e:SetLabel(mg:GetSum(Card.GetLevel))
	Duel.Release(mg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.sefilter(c,e,tp,lv)
	return c:IsSetCard(0xad) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsType(TYPE_FUSION)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sefilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xad) and c:IsType(TYPE_MONSTER)
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsSetCard(0xad) or c:IsSetCard(0xa9) or c:IsSetCard(0xc3))
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end