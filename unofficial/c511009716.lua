--ツイン・ハイドライブ・ナイト
--Twin Hydradrive Knight
--fixed by Larry126 and MLD
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,s.mfilter,2,2)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.attcon)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
end
function s.mfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x577,lc,sumtype,tp) and c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x577) and c:IsLinkMonster() and c:IsLocation(LOCATION_GRAVE)
		and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
end
function s.mgfilter(sg,e,tp,mg)
	return sg:IsExists(aux.NOT(Card.IsAttribute),1,nil,e:GetHandler():GetAttribute())
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=e:GetHandler():GetMaterial():Filter(s.cfilter,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	if chk==0 then return aux.SelectUnselectGroup(mg,e,tp,1,2,s.mgfilter,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=aux.SelectUnselectGroup(mg,e,tp,1,2,s.mgfilter,1,tp,HINTMSG_TARGET,s.mgfilter)
	Duel.SetTargetCard(g)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local att=0
	g:ForEach(function(tc)
		att=att|tc:GetAttribute()
	end)
	if c:IsFaceup() and c:IsRelateToEffect(e) and att>0 and att~=c:GetAttribute() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.distg(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end
