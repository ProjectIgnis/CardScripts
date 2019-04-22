--Sayuri·天空的狂诗曲
local m=210765919
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
cm.Senya_name_with_sayuri=true
function cm.initial_effect(c)
	Senya.AddSummonMusic(c,m*16,SUMMON_TYPE_LINK)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,cm.mfilter,3,3,cm.lcheck)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210765765,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(cm.target)
	e3:SetOperation(cm.operation)
	c:RegisterEffect(e3)
	Senya.NegateEffectModule(c,1,nil,cm.cost)
end
function cm.mfilter(c,lc,sumtype,tp)
	return c:IsFaceup() and Senya.check_link_set_sayuri(c) and c:IsType(TYPE_RITUAL,lc,sumtype,tp)
end
function cm.lcheck(g,lc,tp)
	return not g:IsExists(cm.lfilter,1,nil,g,lc,tp)
end
function cm.lfilter(c,g,lc,tp)
	return g:IsExists(Card.IsSummonCode,1,c,lc,SUMMON_TYPE_LINK,tp,c:GetSummonCode(lc,SUMMON_TYPE_LINK,tp))
end
function cm.cfilter(c,g)
	return g:IsContains(c)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroup(tp,cm.cfilter,1,nil,lg) end
	local g=Duel.SelectReleaseGroup(tp,cm.cfilter,1,1,nil,lg)
	Duel.Release(g,REASON_COST)
end
function cm.filter(c,e,tp,z)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP,tp,z) and Senya.check_set_sayuri(c) and c:GetLevel()==4
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local z=e:GetHandler():GetLinkedZone(tp)
	if z==0 then return false end
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cm.filter(chkc,e,tp,z) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,z) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,z)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local z=e:GetHandler():GetLinkedZone(tp)
	local tc=Duel.GetFirstTarget()
	if z~=0 and tc:IsRelateToEffect(e) and tc:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP,tp,z) then
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP,z)
		tc:CompleteProcedure()
	end
end
