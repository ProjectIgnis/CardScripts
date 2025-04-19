--青眼の白龍 (Deck Master)
--Blue-Eyes White Dragon (Deck Master)
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Can attack
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD)
	dme1:SetCode(511004016)
	dme1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	dme1:SetTargetRange(LOCATION_MZONE,0)
	dme1:SetTarget(s.dmtg)
	DeckMaster.RegisterAbilities(c,dme1)
end
function s.dmtg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsFusionSummoned()
		and (Duel.IsDeckMaster(e:GetOwnerPlayer(),id)
		or c:GetMaterial() and c:GetMaterial():IsContains(e:GetOwner()))
end