--ＤＤＤ聖賢王アルフレッド
--D/D/D Sage King Alfred
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 "D/D" monsters
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DD),2)
	local params={
			fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_DDD),
			matfilter=Card.IsAbleToDeck,
			extrafil=function(e,tp,mg)
						return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_REMOVED,0,nil)
					end,
			extraop=Fusion.ShuffleMaterial,
			extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
						if chk==0 then return true end
						Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_REMOVED)
					end
		}
	--Fusion Summon 1 "D/D/D" Fusion Monster from your Extra Deck, by shuffling its materials from your hand, field, and/or banishment into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
	--Place "Dark Contract" Spell/Traps face-up on your field from your GY and/or banishment, up to the number of "D/D/D" monsters you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DD,SET_DDD,SET_DARK_CONTRACT}
s.material_setcode=SET_DD
function s.plfilter(c,tp)
	return c:IsSetCard(SET_DARK_CONTRACT) and c:IsContinuousSpellTrap() and c:IsFaceup() and c:CheckUniqueOnField(tp)
		and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.plfilter(chkc,tp) end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_DDD),tp,LOCATION_MZONE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return ct>0 and ft>0 and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,math.min(ct,ft),nil,tp)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local gg=Group.CreateGroup()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<#tg then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=tg:FilterSelect(tp,s.plfilter,ft,ft,nil,tp)
		gg=tg-sg
		tg=sg
	end
	for tc in tg:Iter() do
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
	if #gg>0 then
		Duel.SendtoGrave(gg,REASON_RULE|REASON_RETURN,PLAYER_NONE,tp)
	end
end