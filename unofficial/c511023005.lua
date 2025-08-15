--Ｅ・ＨＥＲＯ ダーク・ブライトマン (Anime)
--Elemental HERO Darkbright (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Material: "Elemental HERO Sparkman" + "Elemental HERO Necroshade"
	Fusion.AddProcMix(c,true,true,20721928,89252153)
	c:AddMustBeFusionSummoned()
	--If this card battles a Defense Position monster, inflict piercing damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Change this card to Defense Position at the end of the Damage Step if it attacks
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(function(e) return Duel.GetAttacker()==e:GetHandler() and e:GetHandler():IsRelateToBattle() end)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--Destroy 1 monster your opponent controls if this card is destroyed and send it to the Graveyard
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41517968,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
