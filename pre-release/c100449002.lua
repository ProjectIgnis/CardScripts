--影装騎士 ブラック・ジャク
--Black Jack the Shadow-Armored Knight
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Excavate cards from the top of your Deck until you excavate a monster, equip it to this card as an Equip Spell, also place the rest on the bottom of the Deck in any order
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(function(c) return c:IsControler(1-tp) and c:IsLocation(LOCATION_STZONE) end,1,nil) end)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,nil,function(ec,c,tp) return ec:IsControler(tp) and ec:IsMonster() end,Card.EquipByEffectAndLimitRegister,e2)
	--Gains ATK/DEF equal to the total Levels of the monsters equipped to this card x 300
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3a:SetCode(EFFECT_UPDATE_ATTACK)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetValue(function(e,c) return c:GetEquipGroup():Match(Card.HasLevel,nil):GetSum(Card.GetLevel)*300 end)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3b)
	--If the total Levels of the monsters equipped to this card is greater than 21, destroy this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e) return e:GetHandler():GetEquipGroup():Match(Card.HasLevel,nil):GetSum(Card.GetLevel)>21 end)
	c:RegisterEffect(e4)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if deck_count==0 then return end
	Duel.DisableShuffleCheck()
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_DECK,0,nil)
	if #g==0 then
		Duel.ConfirmDecktop(tp,deck_count)
		Duel.SortDeckbottom(tp,tp,deck_count)
		return
	end
	local c=e:GetHandler()
	local ec=g:GetMaxGroup(Card.GetSequence):GetFirst()
	local ec_seq=ec:GetSequence()
	Duel.ConfirmDecktop(tp,deck_count-ec_seq)
	local top_g=Duel.GetDecktopGroup(tp,deck_count-ec_seq)
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE,0)>0
		and not ec:IsForbidden() and ec:CheckUniqueOnField(tp) then
		c:EquipByEffectAndLimitRegister(e,tp,ec,nil,true)
	else
		Duel.SendtoGrave(ec,REASON_RULE)
	end
	top_g:RemoveCard(ec)
	Duel.MoveToDeckBottom(top_g,tp)
	Duel.SortDeckbottom(tp,tp,#top_g)
end