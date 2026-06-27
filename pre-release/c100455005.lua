--ブルーアイズ・トゥーン・アルティメットドラゴン
--Blue-Eyes Toon Ultimate Dragon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Blue-Eyes Toon Dragon" + 2 Toon monsters
	Fusion.AddProcMixN(c,true,true,53183600,1,s.toonmatfilter,2)
	--Must be Special Summoned (from your Extra Deck) by shuffling the above cards from your hand, field, and/or GY into the Deck/Extra Deck
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--Your Toon monsters can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsType(TYPE_TOON) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Once per turn: You can add 1 "Toon" card, or 1 card that mentions a "Toon" card's name, from your GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--During damage calculation, if your Toon monster is attacked: You can banish it until the end of the Damage Step
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
s.listed_names={53183600} --"Blue-Eyes Toon Dragon"
s.listed_series={SET_TOON}
function s.toonmatfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_TOON,fc,sumtype,tp) and c:IsMonster()
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
end
function s.contactop(g,tp)
	local fu,fd=g:Split(Card.IsFaceup,nil)
	if #fu>0 then Duel.HintSelection(fu) end
	if #fd>0 then Duel.ConfirmCards(1-tp,fd) end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end
function s.thfilter(c)
	return (c:IsSetCard(SET_TOON) or c:ListsCodeWithArchetype(SET_TOON)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	return bc and bc:IsControler(tp) and bc:IsType(TYPE_TOON) and bc:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,Duel.GetAttackTarget(),1,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	if bc and bc:IsRelateToBattle() then
		--Banish it until the end of the Damage Step
		local temp_banish_eff=aux.RemoveUntil(bc,nil,REASON_EFFECT,PHASE_DAMAGE,id,e,tp,aux.DefaultFieldReturnOp)
		local e1=temp_banish_eff:Clone()
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		Duel.RegisterEffect(e1,tp)
		temp_banish_eff:Reset()
	end
end