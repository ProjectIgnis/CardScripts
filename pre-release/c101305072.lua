--エルフェンノーツ～継唱のクウォートレイン～
--Elfnotes: Quatrain of Succession
--scripted by pyrQ
local s,id=GetID()
local TOKEN_ELFNOTE_SERAPHIM=id+100
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--The monster in your center Main Monster Zone cannot be banished by your opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.rmlimit)
	c:RegisterEffect(e1)
	--You can send 1 other Spell/Trap from your hand or field to the GY and declare a Level from 1 to 4; Special Summon 1 "Elfnote Seraphim Token" (Plant/Tuner/FIRE/ATK 0/DEF 0) with the declared Level, but while that Token is in the Monster Zone, the player who Summoned it cannot Special Summon from the Extra Deck, except "Elfnote" monsters. You can only use this effect of "Elfnotes: Quatrain of Succession" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.tokencost)
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_ELFNOTE_SERAPHIM}
s.listed_series={SET_ELFNOTE}
function s.rmlimit(e,c,tp,r)
	return c:IsSequence(2) and c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_MZONE) and not c:IsImmuneToEffect(e) and r&REASON_EFFECT>0
end
function s.tokencostfilter(c,tp)
	return c:IsSpellTrap() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tokencostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tokencostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local exceptions={}
	for lv=1,4 do
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ELFNOTE_SERAPHIM,SET_ELFNOTE,TYPES_TOKEN|TYPE_TUNER,0,0,lv,RACE_PLANT,ATTRIBUTE_FIRE) then
			table.insert(exceptions,lv)
		end
	end
	if chk==0 then return #exceptions<4 end
	local declared_lv=Duel.AnnounceLevel(tp,1,4,exceptions)
	e:SetLabel(declared_lv)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	if Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ELFNOTE_SERAPHIM,SET_ELFNOTE,TYPES_TOKEN|TYPE_TUNER,0,0,lv,RACE_PLANT,ATTRIBUTE_FIRE) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,TOKEN_ELFNOTE_SERAPHIM)
		--Set the Token's Level to the declared Level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
		token:RegisterEffect(e1)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			--While that Token is in the Monster Zone, the player who Summoned it cannot Special Summon from the Extra Deck, except "Elfnote" monsters
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetRange(LOCATION_MZONE)
			e2:SetAbsoluteRange(tp,1,0)
			e2:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_ELFNOTE) end)
			e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
			token:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end