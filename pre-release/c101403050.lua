--竜魔導の降霊師
--Necromancer of Dragon Magic
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	--During your Main Phase: You can reveal 1 Fusion Monster in your Extra Deck, choose 1 non-Fusion Monster in your GY whose name is mentioned on the revealed monster, and this card's name becomes that monster's (until the End Phase), then you can Fusion Summon the revealed Fusion Monster, by banishing its materials from your hand, field, and/or GY, also you cannot Special Summon from the Extra Deck for the rest of this turn, except Fusion Monsters. You can only use this effect of "Necromancer of Dragon Magic" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)
end
function s.revealfilter(c,tp,handler_name)
	return c:IsFusionMonster() and (c.material or c.listed_names) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,c,handler_name)
end
function s.gyfilter(c,fusion_monster,handler_name)
	if c:IsFusionMonster() or c:IsCode(handler_name) then return false end
	local code=c:GetCode()
	return fusion_monster:ListsCode(code) or fusion_monster:ListsCodeAsMaterial(code)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil,tp,e:GetHandler():GetCode()) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local handler_name=c:GetCode()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local fusion_monster=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp,handler_name):GetFirst()
		if fusion_monster then
			Duel.ConfirmCards(1-tp,fusion_monster)
			Duel.ShuffleExtra(tp)
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			local sc=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,fusion_monster,handler_name):GetFirst()
			if sc then
				Duel.HintSelection(sc)
				--This card's name becomes that monster's (until the End Phase)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_CODE)
				e1:SetValue(sc:GetCode())
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				c:RegisterEffect(e1)
				Duel.AdjustInstantly(c)
				local fusion_params={
					handler=c,
					fusfilter=function(summon_card)
						return summon_card==fusion_monster
					end,
					matfilter=Card.IsAbleToRemove,
					extrafil=function(e,tp,mg)
						if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
							return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
						end
						return nil
					end,
					extraop=Fusion.BanishMaterial
				}
				if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.BreakEffect()
					Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp,1)
				end
			end
		end
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Fusion Monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_EXTRA) and not c:IsFusionMonster()
	end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(c,tp,function(c) return not c:IsOriginalType(TYPE_FUSION) end)
end