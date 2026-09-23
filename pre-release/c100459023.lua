--鋼鉄の騎士 ギア・フリード
--Gearfried the Steel Knight
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If a monster(s) you control was destroyed by battle or card effect this turn (Quick Effect): You can Special Summon card from your hand, and if you do, equip 1 monster from your GY to it as an Equip Spell that gives it 800 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.HasFlagEffect(tp,id)
	end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Keep track of a monster(s) on the field being destroyed by battle or card effect
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			for ec in eg:Iter() do
				local prev_ctlr=ec:GetPreviousControler()
				if ec:IsPreviousLocation(LOCATION_MZONE) and ec:IsReason(REASON_BATTLE|REASON_EFFECT)
					and not Duel.HasFlagEffect(prev_ctlr,id) then
					Duel.RegisterFlagEffect(prev_ctlr,id,RESET_PHASE|PHASE_END,0,1)
				end
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
	aux.AddEREquipLimit(c,nil,function(ec,_,tp) return s.eqfilter(ec,tp) end,s.equipop,e1)
	--During your Main Phase: You can destroy as many cards equipped to this card as possible, then if you destroyed a Monster Card by this effect, you can add 1 monster from your Deck to your hand with the same Attribute and Type as 1 of them, but a different Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.eqfilter(c,tp)
	return c:IsMonster() and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if ec then
			s.equipop(c,e,tp,ec)
		end
	end
end
function s.equipop(c,e,tp,ec)
	if not c:EquipByEffectAndLimitRegister(e,tp,ec,id) then return end
	--Equip 1 monster from your GY to it as an Equip Spell that gives it 800 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	ec:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetEquipGroup()
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c,mg)
	return c:IsMonster() and mg:IsExists(s.propfilter,1,nil,c:GetAttribute(),c:GetRace(),c:GetLevel())
end
function s.propfilter(c,attr,race,lv)
	return c:IsAttribute(attr) and c:IsRace(race) and not c:IsLevel(lv)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetEquipGroup()
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local mg=Duel.GetOperatedGroup():Filter(aux.AND(Card.IsMonsterCard,Card.HasLevel),nil)
		if #mg>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,mg)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,mg)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end