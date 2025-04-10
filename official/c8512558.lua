--希望皇オノマトピア
--Utopic Onomatopoeia
--Scripted by Logical Nonsense, AlphaKretin, and edo9300
local s,id=GetID()
function s.initial_effect(c)
	--This card is always treated as a "Zubaba" card (required due to current cdb limitations)
	c:AddSetcodesRule(id,true,SET_ZUBABA)
	--Special Summon up to 1 each "Zubaba", "Gagaga", "Gogogo", and/or "Dododo" monster(s) from your hand in Defense Position, except "Utopic Onomatopoeia"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_ZUBABA,SET_GAGAGA,SET_GOGOGO,SET_DODODO}
function s.spfilter(c,e,tp)
	return c:IsSetCard({SET_ZUBABA,SET_GAGAGA,SET_GOGOGO,SET_DODODO}) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.rescon(checkfunc)
	return function(sg,e,tp,mg)
		return true,not aux.ChkfMMZ(#sg)(sg,e,tp,mg) or not sg:CheckDifferentProperty(checkfunc)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0 and aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(aux.PropertyTableFilter(Card.GetSetCard,SET_ZUBABA,SET_GAGAGA,SET_GOGOGO,SET_DODODO)),0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),4)
	if #g>0 and ft>0 then 
		local checkfunc=aux.PropertyTableFilter(Card.GetSetCard,SET_ZUBABA,SET_GAGAGA,SET_GOGOGO,SET_DODODO)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(checkfunc),1,tp,HINTMSG_SPSUMMON,s.rescon(checkfunc))
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	local c=e:GetHandler()
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalType(TYPE_XYZ) end)
end
