--Ｎｏ．６９ 紋章神コート・オブ・アームズ－ゴッド・シャーター
--Number 69: Heraldry Crest - Shatter Stream
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 4 Level 4 monsters OR 1 monster whose original name is "Number 69: Heraldry Crest"
	Xyz.AddProcedure(c,nil,4,4,s.ovfilter,aux.Stringid(id,0),4)
	--Special Summon 1 "Number 69: Heraldry Crest - Dark Matter Demolition" from your Extra Deck and destroy an opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	c:RegisterEffect(e2)
end
s.xyz_number=69
s.listed_series={2407234,77571454} --"Number 69: Heraldry Crest", "Number 69: Heraldry Crest - Dark Matter Demolition"
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsOriginalCodeRule(2407234)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ttype,tloc,tplayer=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	return ttype&TYPE_MONSTER>0 and tloc&LOCATION_ONFIELD>0 and tplayer==1-tp
end
function s.xyzfilter(c,e,tp,mc)
	return c:IsCode(77571454) and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return (#pg<=0 or (#pg==1 and pg:IsContains(c)))
			and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e)) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if #pg>1 or (#pg==1 and not pg:IsContains(c)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyzc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
	if not xyzc then return end
	xyzc:SetMaterial(c)
	Duel.Overlay(xyzc,c)
	if Duel.SpecialSummon(xyzc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		xyzc:CompleteProcedure()
		local dg=Duel.GetFirstTarget()
		if dg:IsControler(1-tp) and dg:IsRelateToEffect(e)
			and (Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) or dg:IsRelateToEffect(re)) then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end