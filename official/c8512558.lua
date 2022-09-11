--希望皇オノマトピア
--Utopic Onomatopeia
--Scripted by Logical Nonsense and AlphaKretin, revised handling of archetype check by edo9300
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,true,0x8f) --required due to current cdb limitations
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={0x54,0x59,0x82,0x8f}
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:IsSetCard(0x54) or c:IsSetCard(0x59) or c:IsSetCard(0x82) or  c:IsSetCard(0x8f)) and not c:IsCode(id)
end
function s.rescon(checkfunc)
	return function(sg,e,tp,mg)
		return true,not aux.ChkfMMZ(#sg)(sg,e,tp,mg) or not sg:CheckDifferentProperty(checkfunc)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0 and aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(aux.PropertyTableFilter(Card.GetSetCard,0x54,0x59,0x82,0x8f)),0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),4)
	if #g>0 and ft>0 then 
		local checkfunc=aux.PropertyTableFilter(Card.GetSetCard,0x54,0x59,0x82,0x8f)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(checkfunc),1,tp,HINTMSG_SPSUMMON,s.rescon(checkfunc))
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end 
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,5),nil)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_XYZ)
end