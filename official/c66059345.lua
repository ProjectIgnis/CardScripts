--原質の炉心貫通
--Materiactor Meltthrough
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 6 cards of your Deck, and if you do, place them on top of the Deck in any order
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.excavtg)
	e1:SetOperation(s.excavop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Materiactor" Xyz Monster from your Extra Deck, by using 1 Level 3 Normal Monster you control as material (this is treated as an Xyz Summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.PayLP(1500))
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	--Attach the top card of your Deck to 1 "Materiactor" Xyz Monster you control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(function(e,tp,eg) return eg:IsExists(function(c) return c:IsXyzSummoned() and c:IsType(TYPE_XYZ) and c:IsFaceup() end,1,nil) end)
	e3:SetTarget(s.attachtg)
	e3:SetOperation(s.attachop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MATERIACTOR}
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6 end
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
		Duel.ConfirmDecktop(tp,6)
		Duel.SortDecktop(tp,tp,6)
	end
end
function s.normalfilter(c,e,tp)
	if not (c:IsLevel(3) and c:IsType(TYPE_NORMAL) and c:IsFaceup()) then return false end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and Duel.IsExistingMatchingCard(s.xyzspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.xyzspfilter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_MATERIACTOR) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 
		and mc:IsCanBeXyzMaterial(c,tp) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.normalfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mc=Duel.SelectMatchingCard(tp,s.normalfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if mc then
		Duel.HintSelection(mc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.xyzspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc):GetFirst()
		if sc then
			sc:SetMaterial(mc)
			Duel.Overlay(sc,mc)
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()
			end
		end
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Xyz Monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.attachfilter(c,tp,top_c)
	return c:IsSetCard(SET_MATERIACTOR) and c:IsType(TYPE_XYZ) and c:IsFaceup() and top_c:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local top_c=Duel.GetDecktopGroup(tp,1):GetFirst()
		return top_c and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_MZONE,0,1,nil,tp,top_c)
	end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local top_c=Duel.GetDecktopGroup(tp,1):GetFirst()
	if not top_c then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local xyzc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,top_c):GetFirst()
	if xyzc then
		Duel.HintSelection(xyzc)
		Duel.DisableShuffleCheck()
		Duel.Overlay(xyzc,top_c)
	end
end