--武装転生
--Armament Reincarnation
--scripted by pyrQ
local s,id=GetID()
local TOKEN_ARMAMENT_REINCARNATION=id+1
function s.initial_effect(c)
	--Special Summon "Armament Reincarnation Tokens" (Warrior/LIGHT/Level 1/ATK 500/DEF 500) up to the number of Equip Spells, and Traps with an effect that equip themselves to a monster, in your GY, then you can destroy as many cards in your Spell & Trap Zone as possible, including this card, then Set as many Equip Spells, and Traps with an effect that equip themselves to a monster, as possible from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={TOKEN_ARMAMENT_REINCARNATION}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARMAMENT_REINCARNATION,0,TYPES_TOKEN,500,500,1,RACE_WARRIOR,ATTRIBUTE_LIGHT)
		and Duel.IsExistingMatchingCard(aux.OR(Card.IsEquipSpell,Card.IsEquipTrap),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
end
function s.setfilter(c)
	return (c:IsEquipSpell() or c:IsEquipTrap()) and c:IsSSetable(true)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local max_ct=Duel.GetMatchingGroupCount(aux.OR(Card.IsEquipSpell,Card.IsEquipTrap),tp,LOCATION_GRAVE,0,nil)
	if ft>0 and max_ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARMAMENT_REINCARNATION,0,TYPES_TOKEN,500,500,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		ft=math.min(ft,max_ct)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if ft>1 then
			ft=Duel.AnnounceNumberRange(tp,1,ft)
		end
		for i=1,ft do
			local token=Duel.CreateToken(tp,TOKEN_ARMAMENT_REINCARNATION)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		if Duel.SpecialSummonComplete()>0 and c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE)
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g=Duel.GetFieldGroup(tp,LOCATION_STZONE,0)
			Duel.BreakEffect()
			if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsContains(c)then
				local st_zones=Duel.GetLocationCount(tp,LOCATION_SZONE,0)
				if st_zones>0 then
					local equip_g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,nil)
					local sg=Group.CreateGroup()
					if #equip_g>st_zones then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
						sg=equip_g:Select(tp,st_zones,st_zones,nil)
					else
						sg=equip_g
					end
					if #sg>0 then
						Duel.BreakEffect()
						if Duel.SSet(tp,sg)>0 then
							local set_traps=Duel.GetOperatedGroup():Match(Card.IsTrap,nil)
							for sc in set_traps:Iter() do
								--These Traps can be activated this turn
								local e1=Effect.CreateEffect(c)
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
								e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
								e1:SetReset(RESETS_STANDARD_PHASE_END)
								sc:RegisterEffect(e1)
							end
						end
					end
				end
			end
		end
	end
	--For the rest of this turn, you cannot Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end