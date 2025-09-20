--佚楽の堕天使
--Darklord Pleasure
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 DARK Fairy Fusion Monster from your Extra Deck, by banishing its materials from your hand, field, and/or GY, and if you do, it gains 1000 ATK
	local e1=Fusion.CreateSummonEff({
				handler=c,
				fusfilter=s.fusfilter,
				matfilter=Card.IsAbleToRemove,
				extrafil=s.fextra,
				extraop=Fusion.BanishMaterial,
				extratg=s.extratg,
				stage2=s.stage2
			})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARKLORD}
function s.fusfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY)
end
function s.fcheck(tp,sg,fc)
	return fc:IsSetCard(SET_DARKLORD) or not sg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.fextrafilter(c,tp)
	return c:IsMonster() and c:IsAbleToRemove() and (c:IsControler(tp) or (c:IsSetCard(SET_DARKLORD) and c:IsFaceup()))
end
function s.fextra(e,tp,mg)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then return nil,s.fcheck end
	return Duel.GetMatchingGroup(s.fextrafilter,tp,LOCATION_GRAVE,LOCATION_MZONE,nil,tp),s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
end
function s.stage2(e,fc,tp,sg,chk)
	if chk==0 then
		--It gains 1000 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		fc:RegisterEffect(e1)
	end
end