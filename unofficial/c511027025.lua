--黒薔薇の魔女 (Anime)
--Witch of the Black Rose (Anime)
--added by ClaireStanfield
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		if not tc:IsType(TYPE_MONSTER) then
			Duel.BreakEffect()
			if e:GetHandler():IsRelateToEffect(e) then
				Duel.Destroy(e:GetHandler(),REASON_EFFECT)
			end
		end
		Duel.ShuffleHand(tp)
	end
end
