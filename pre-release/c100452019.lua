--デミウルゴス ＥＭＡ
--Demiurge Ema
--scripted by Naim
local s,id=GetID()
local TOKEN_HOMUNCULUS=id+100
function s.initial_effect(c)
	--You can send 4 monsters with 2400 or more ATK and 1000 DEF from your hand, Deck, and/or face-up field to the GY; Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.selfspcost)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--You can target 1 Spell/Trap on each field; destroy them, then Special Summon 1 "Homunculus Token" (Fairy/LIGHT/Level 2/ATK 800/DEF 800) to both players' fields in Defense Position, and if you do, this card gains 1600 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.tkntg)
	e2:SetOperation(s.tknop)
	e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_HOMUNCULUS}
function s.selfspcostfilter(c)
	return c:IsAttackAbove(2400) and c:IsDefense(1000) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToGraveAsCost()
end
function s.selfspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,e:GetHandler())
	if chk==0 then return #g>=4 and Duel.GetMZoneCount(tp,g)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,4,4,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cansummontokentothisplayer(sum_player,target_player)
	return Duel.IsPlayerCanSpecialSummonMonster(sum_player,TOKEN_HOMUNCULUS,0,TYPES_TOKEN,800,800,2,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,target_player)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetControler,nil)==2 and Duel.GetMZoneCount(tp,sg)>0 and Duel.GetMZoneCount(1-tp,sg)>0
end
function s.tkntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and s.cansummontokentothisplayer(tp,tp)
		and s.cansummontokentothisplayer(tp,1-tp)
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,0,2,PLAYER_ALL,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,0,2,PLAYER_ALL,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,1600)
end
function s.tknop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.Destroy(tg,REASON_EFFECT)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and s.cansummontokentothisplayer(tp,tp) and s.cansummontokentothisplayer(tp,1-tp) then
		Duel.BreakEffect()
		local token1=Duel.CreateToken(tp,TOKEN_HOMUNCULUS)
		Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local token2=Duel.CreateToken(tp,TOKEN_HOMUNCULUS)
		Duel.SpecialSummonStep(token2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		if Duel.SpecialSummonComplete()==0 then return end
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--This card gains 1600 ATK
			c:UpdateAttack(1600)
		end
	end
end