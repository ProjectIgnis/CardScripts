--エクシーズ・アーマー・フォートレス
--Xyz Armor Fortress
--Sripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 5 monsters OR 1 Rank 3 or 4 Xyz Monster you control
	Xyz.AddProcedure(c,nil,5,2,s.xyzfilter,aux.Stringid(id,0),2,s.xyzop)
	--Cannot be used as material for an Xyz Summon while it has material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Add "Armored Xyz" cards with different names from your Deck to your hand, equal to the number of materials detached
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Detach(1,s.thmaxcost,function(e,og) e:SetLabel(#og) end))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If a monster equipped with this card battles a monster, any battle damage it inflicts to your opponent is doubled
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget():GetBattleTarget() end)
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ARMORED_XYZ}
function s.xyzfilter(c,tp,xyzc)
	return c:IsRank(3,4) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.thfilter(c)
	return c:IsSetCard(SET_ARMORED_XYZ) and c:IsAbleToHand()
end
function s.thmaxcost(e,tp)
	return math.min(2,Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel(),tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<ct then return end
	local thg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #thg>0 then
		Duel.SendtoHand(thg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,thg)
	end
end