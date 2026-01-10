--道化の一座 ディアボロ
--Clown Crew Diablo
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 monsters with the same Attribute but different Types
	Fusion.AddProcMixN(c,true,true,s.fusfilter,2)
	--If your Tribute Summoned monster attacks a Defense Position monster, inflict double piercing battle damage to your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsTributeSummoned))
	e1:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e1)
	--If this card is Tributed: You can activate 1 of these effects (but you can only use each of these effects of "Clown Crew Diablo" once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CLOWN_CREW}
function s.fusfilter(c,fc,sumtype,sp,sub,mg,sg)
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(),fc,sumtype,sp) and not sg:IsExists(Card.IsRace,1,c,c:GetRace(),fc,sumtype,sp))
end
function s.setfilter(c)
	return c:IsSetCard(SET_CLOWN_CREW) and c:IsTrap() and c:IsSSetable()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFusionMonster,Card.IsFaceup,Card.IsAbleToExtra),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+100)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOEXTRA)
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,PLAYER_ALL,LOCATION_MZONE|LOCATION_GRAVE)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Return all Fusion Monsters on the field and in the GYs to the Extra Deck
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsFusionMonster,Card.IsFaceup,Card.IsAbleToExtra),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif op==2 then
		--● Set 1 "Clown Crew" Trap from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	end
end