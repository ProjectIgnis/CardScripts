--召喚獣エリュシオン
--Invoked Elysium
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion materials
	Fusion.AddProcMix(c,false,false,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_INVOKED),s.ffilter2)
	--Must first be Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Treated as DARK, EARTH, WATER, FIRE and WIND
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND|ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	--Banish 1 "Invoked" monster and monsters with the same attribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_INVOKED}
s.material_setcode=SET_INVOKED
function s.ffilter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
function s.rmfilter1(c)
	return c:IsSetCard(SET_INVOKED) and c:IsMonster() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsAbleToRemove() and aux.SpElimFilter(c,true,true)
end
function s.rmfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter1,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,s.rmfilter1,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	local g2=Duel.GetMatchingGroup(s.rmfilter2,tp,0,LOCATION_MZONE,nil,g1:GetFirst():GetAttribute())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local tg=Group.FromCards(tc)
		if tc:IsFaceup() then
			local g=Duel.GetMatchingGroup(s.rmfilter2,tp,0,LOCATION_MZONE,nil,tc:GetAttribute())
			tg:Merge(g)
		end
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end