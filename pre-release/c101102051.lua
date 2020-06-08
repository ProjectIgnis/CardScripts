--ＲＵＭ－ファントム・フォース
--Rank-Up-Magic - Phantom Knights' Force
--scripted by AlphaKretin and by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x10db,0xba,0x2073}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.filter1(c,e,tp,sg,exg,dr)
	local rk=c:GetRank()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return #pg<=1 and c:IsFaceup() and (rk>0 or c:IsStatus(STATUS_NO_LEVEL)) 
		and exg:IsExists(s.filter2,1,nil,e,tp,c,rk+dr,pg,sg)
end
function s.filter2(c,e,tp,mc,rk,pg,sg)
	if c.rum_limit and not c.rum_limit(mc,e) or Duel.GetLocationCountFromEx(tp,tp,sg+mc,c)<=0 then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and mc:IsAttribute(ATTRIBUTE_DARK,c,SUMMON_TYPE_XYZ,tp) and c:IsRank(rk) 
		and mc:IsCanBeXyzMaterial(c,tp) and (#pg<=0 or pg:IsContains(mc))
end
function s.rescon(exg,fg)
	return	function(sg,e,tp,mg)
		return fg:IsExists(s.filter1,1,sg,e,tp,sg,exg,#sg)
	end
end
function s.rmfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function s.extrafil(c)
	return c:IsSetCard(0x10db) or c:IsSetCard(0xba) or c:IsSetCard(0x2073) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.fieldfil(c)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local exg=Duel.GetMatchingGroup(s.extrafil,tp,LOCATION_EXTRA,0,nil)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.fieldfil(chkc) and s.filter1(chkc,e,tp,Group.FromCards(chkc),exg,e:GetLabel()) end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	local fg=Duel.GetMatchingGroup(s.fieldfil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then 
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return #fg>0 and #g>0 and #exg>0 and aux.SelectUnselectGroup(g,e,tp,nil,nil,s.rescon(exg,fg),0)
	end
	local rg=aux.SelectUnselectGroup(g,e,tp,nil,nil,s.rescon(exg,fg),1,tp,HINTMSG_REMOVE,s.rescon(exg,fg))
	local dr=#rg
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp,rg,exg,dr)
	e:SetLabel(dr)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetDescription(aux.Stringid(id,1))
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+e:GetLabel(),pg,Group.FromCards(tc))
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
