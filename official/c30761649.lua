--冀望郷－バリアン－
--Barian Untopia
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--"Number" monsters between "101" and "107", "CXyz" monsters, and "Number C" monsters you control cannot be destroyed by your opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.protectiontg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--Your opponent cannot target "Number" monsters between "101" and "107", "CXyz" monsters, and "Number C" monsters you control with card effects
	local e2=e1:Clone()
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Attach 1 monster your opponent controls to 1 Xyz Monster you Special Summoned with a "Rank-Up-Magic" Spell's effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.attachcon)
	e3:SetTarget(s.attachtg)
	e3:SetOperation(s.attachop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BARIANS,SET_NUMBER,SET_CXYZ,SET_NUMBER_C,SET_RANK_UP_MAGIC}
function s.protectiontg(e,c)
	local no=c.xyz_number
	return ((c:IsSetCard(SET_NUMBER) and no and no>=101 and no<=107) or c:IsSetCard({SET_CXYZ,SET_NUMBER_C})) and c:IsFaceup()
end
function s.attachconfilter(c,tp,re)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(tp) and re and re:IsSpellEffect()
		and re:GetHandler():IsSetCard(SET_RANK_UP_MAGIC)
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.attachconfilter,1,nil,tp,re)
end
function s.xyztgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and Duel.IsExistingTarget(s.attachfilter,tp,0,LOCATION_MZONE,1,c,e,c,tp)
end
function s.attachfilter(c,e,xyzc,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local xyzg=eg:Filter(s.attachconfilter,nil,tp,re):Match(s.xyztgfilter,nil,e,tp)
	if chk==0 then return #xyzg>0 end
	local xyzc=nil
	if #xyzg==1 then
		xyzc=xyzg:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		xyzc=xyzg:Select(tp,1,1,nil):GetFirst()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectMatchingCard(tp,s.attachfilter,tp,0,LOCATION_MZONE,1,1,xyzc,e,xyzc,tp)
	Duel.SetTargetCard(g+xyzc)
	e:SetLabelObject(xyzc)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local xyzc=e:GetLabelObject()
	if not (xyzc:IsRelateToEffect(e) and xyzc:IsFaceup() and not xyzc:IsImmuneToEffect(e)) then return end
	local attach_tc=(Duel.GetTargetCards(e)-xyzc):GetFirst()
	if attach_tc and attach_tc:IsControler(1-tp) and not attach_tc:IsImmuneToEffect(e) then
		Duel.Overlay(xyzc,attach_tc,true)
	end
end