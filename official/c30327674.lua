--カオス・ウィッチ－混沌の魔女
--Chaos Witch
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 "Black Beast Tokens"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetLabel(id+1,0,TYPES_TOKEN,1000,500,2,RACE_FIEND,ATTRIBUTE_DARK)
	e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	--Special Summon 2 "White Beast Tokens"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetLabel(id+2,0,TYPES_TOKEN+TYPE_TUNER,500,1000,2,RACE_FAIRY,ATTRIBUTE_LIGHT)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND|LOCATION_GRAVE) end)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	--Count Special Summoned monsters
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.ctfilter)
end
s.listed_names={id+1,id+2}
function s.synfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
end
function s.ctfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or s.synfilter(c)
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local blk=(e:GetLabel())==id+1
	if chk==0 then
		if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>0 then return false end
		return not blk or c:IsReleasable()
	end
	if blk then Duel.Release(c,REASON_COST) end
	--Cannot Special Summon monsters from the Extra Deck, except LIGHT or DARK Synchro monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not s.synfilter(c) end)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_SYNCHRO) or not c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,e:GetLabel())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local tk=e:GetLabel()
		for _=1,2 do
			local token=Duel.CreateToken(tp,tk)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
end